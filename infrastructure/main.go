package main

import (
	"fmt"

	"github.com/pulumi/pulumi-gcp/sdk/v6/go/gcp"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Get configuration
		cfg := config.New(ctx, "")
		project := cfg.Require("gcp:project")
		region := cfg.Get("gcp:region")
		domainName := cfg.Require("domain-name")
		environment := cfg.Get("environment")

		// Create GKE cluster
		cluster, err := createGKECluster(ctx, project, region, environment)
		if err != nil {
			return err
		}

		// Create DNS zone and certificates
		dnsZone, err := createDNSZone(ctx, project, domainName)
		if err != nil {
			return err
		}

		// Create managed SSL certificate
		certificate, err := createSSLCertificate(ctx, domainName)
		if err != nil {
			return err
		}

		// Create external IP for load balancer
		externalIP, err := createExternalIP(ctx, project, region)
		if err != nil {
			return err
		}

		// Create Kubernetes provider
		k8sProvider, err := createK8sProvider(ctx, cluster)
		if err != nil {
			return err
		}

		// Deploy Helm chart
		helmRelease, err := deployHelmChart(ctx, k8sProvider, externalIP, certificate, domainName)
		if err != nil {
			return err
		}

		// Export outputs
		ctx.Export("clusterName", cluster.Name)
		ctx.Export("clusterEndpoint", cluster.Endpoint)
		ctx.Export("externalIP", externalIP.Address)
		ctx.Export("domainName", pulumi.String(domainName))
		ctx.Export("kubeconfig", cluster.MasterAuth.ClusterCaCertificate())

		return nil
	})
}

func createGKECluster(ctx *pulumi.Context, project, region, environment string) (*gcp.Container.Cluster, error) {
	cluster, err := gcp.Container.NewCluster(ctx, fmt.Sprintf("grpc-cluster-%s", environment), &gcp.Container.ClusterArgs{
		Project:  pulumi.String(project),
		Location: pulumi.String(region),
		Network:  pulumi.String("default"),
		Subnetwork: pulumi.String("default"),
		RemoveDefaultNodePool: pulumi.Bool(true),
		InitialNodeCount:      pulumi.Int(1),
		MasterAuth: &gcp.Container.ClusterMasterAuthArgs{
			ClientCertificateConfig: &gcp.Container.ClusterMasterAuthClientCertificateConfigArgs{
				IssueClientCertificate: pulumi.Bool(false),
			},
		},
		WorkloadIdentityConfig: &gcp.Container.ClusterWorkloadIdentityConfigArgs{
			WorkloadPool: pulumi.Sprintf("%s.svc.id.goog", project),
		},
		AddonsConfig: &gcp.Container.ClusterAddonsConfigArgs{
			HttpLoadBalancing: &gcp.Container.ClusterAddonsConfigHttpLoadBalancingArgs{
				Disabled: pulumi.Bool(false),
			},
			HorizontalPodAutoscaling: &gcp.Container.ClusterAddonsConfigHorizontalPodAutoscalingArgs{
				Disabled: pulumi.Bool(false),
			},
		},
		ReleaseChannel: &gcp.Container.ClusterReleaseChannelArgs{
			Channel: pulumi.String("REGULAR"),
		},
	})
	if err != nil {
		return nil, err
	}

	// Create node pool
	_, err = gcp.Container.NewNodePool(ctx, fmt.Sprintf("grpc-node-pool-%s", environment), &gcp.Container.NodePoolArgs{
		Project:  pulumi.String(project),
		Location: pulumi.String(region),
		Cluster:  cluster.Name,
		NodeCount: pulumi.Int(3),
		NodeConfig: &gcp.Container.NodePoolNodeConfigArgs{
			MachineType: pulumi.String("e2-standard-2"),
			DiskSizeGb:  pulumi.Int(50),
			DiskType:    pulumi.String("pd-standard"),
			ImageType:   pulumi.String("COS_CONTAINERD"),
			OauthScopes: pulumi.StringArray{
				pulumi.String("https://www.googleapis.com/auth/devstorage.read_only"),
				pulumi.String("https://www.googleapis.com/auth/logging.write"),
				pulumi.String("https://www.googleapis.com/auth/monitoring"),
				pulumi.String("https://www.googleapis.com/auth/compute"),
			},
			WorkloadMetadataConfig: &gcp.Container.NodePoolNodeConfigWorkloadMetadataConfigArgs{
				Mode: pulumi.String("GKE_METADATA"),
			},
		},
		Autoscaling: &gcp.Container.NodePoolAutoscalingArgs{
			MinNodeCount: pulumi.Int(1),
			MaxNodeCount: pulumi.Int(10),
		},
		Management: &gcp.Container.NodePoolManagementArgs{
			AutoRepair:  pulumi.Bool(true),
			AutoUpgrade: pulumi.Bool(true),
		},
	})
	if err != nil {
		return nil, err
	}

	return cluster, nil
}

func createDNSZone(ctx *pulumi.Context, project, domainName string) (*gcp.Dns.ManagedZone, error) {
	return gcp.Dns.NewManagedZone(ctx, "grpc-dns-zone", &gcp.Dns.ManagedZoneArgs{
		Project:     pulumi.String(project),
		Name:        pulumi.String("grpc-zone"),
		DnsName:     pulumi.Sprintf("%s.", domainName),
		Description: pulumi.String("DNS zone for gRPC service"),
		Visibility:  pulumi.String("public"),
	})
}

func createSSLCertificate(ctx *pulumi.Context, domainName string) (*gcp.Compute.ManagedSslCertificate, error) {
	return gcp.Compute.NewManagedSslCertificate(ctx, "grpc-ssl-cert", &gcp.Compute.ManagedSslCertificateArgs{
		Managed: &gcp.Compute.ManagedSslCertificateManagedArgs{
			Domains: pulumi.StringArray{
				pulumi.String(domainName),
				pulumi.Sprintf("*.%s", domainName),
			},
		},
	})
}

func createExternalIP(ctx *pulumi.Context, project, region string) (*gcp.Compute.Address, error) {
	return gcp.Compute.NewAddress(ctx, "grpc-external-ip", &gcp.Compute.AddressArgs{
		Project:  pulumi.String(project),
		Region:   pulumi.String(region),
		Name:     pulumi.String("grpc-external-ip"),
		AddressType: pulumi.String("EXTERNAL"),
	})
}

func createK8sProvider(ctx *pulumi.Context, cluster *gcp.Container.Cluster) (*kubernetes.Provider, error) {
	return kubernetes.NewProvider(ctx, "gke-k8s", &kubernetes.ProviderArgs{
		Kubeconfig: cluster.MasterAuth.ClusterCaCertificate(),
	})
}

func deployHelmChart(ctx *pulumi.Context, k8sProvider *kubernetes.Provider, externalIP *gcp.Compute.Address, certificate *gcp.Compute.ManagedSslCertificate, domainName string) (*helm.Release, error) {
	return helm.NewRelease(ctx, "grpc-service", &helm.ReleaseArgs{
		Chart:     pulumi.String("helm/grpc-service"),
		Namespace: pulumi.String("default"),
		Values: pulumi.Map{
			"ingress": pulumi.Map{
				"enabled": pulumi.Bool(true),
				"hosts": pulumi.Array{
					pulumi.Map{
						"host": pulumi.String(domainName),
						"paths": pulumi.Array{
							pulumi.Map{
								"path":     pulumi.String("/"),
								"pathType": pulumi.String("Prefix"),
							},
						},
					},
				},
				"tls": pulumi.Array{
					pulumi.Map{
						"secretName": pulumi.String("grpc-tls"),
						"hosts": pulumi.Array{
							pulumi.String(domainName),
						},
					},
				},
			},
			"service": pulumi.Map{
				"type": pulumi.String("LoadBalancer"),
				"annotations": pulumi.Map{
					"service.beta.kubernetes.io/google-load-balancer-ssl-certificates": certificate.SelfLink,
				},
			},
		},
	}, pulumi.Provider(k8sProvider))
}
