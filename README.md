# OpenDesk OCM K8s Toolkit PoC

## About this project

This repository contains a Proof of Concept (PoC) implementation of [OpenDesk](https://www.opendesk.eu), a comprehensive digital workplace platform built on cloud-native technologies. The project demonstrates the deployment and management of a complete office suite including collaboration tools, communication platforms, file sharing, and project management applications using modern GitOps practices with [OCM Kubernetes Controller Toolkit](https://github.com/open-component-model/open-component-model/tree/main/kubernetes/controller) and [KRO](https://kro.run/) resource orchestration.

The platform includes core applications such as Nextcloud, Element/Matrix, OpenProject, Collabora, Jitsi, and XWiki, orchestrated through the [Open Component Model (OCM)](https://ocm.software/) and deployed via [Kubernetes Resource Orchestrator (KRO)]((https://kro.run/)) with [FluxCD](https://fluxcd.io/) as the underlying deployment engine.


## Deployment Instructions

### Building OCM Components

#### Generate and package the Helmfile values and ConfigMaps

Before building and transferring the OCM components, the Helmfile values files need to be generated and packaged as ConfigMaps. This is done automatically by the `.github/workflows/pr-helmfiles-build.yaml` workflow for each pull request targeting the `main` branch. This workflow prepares the Helmfile manifests, generates the `values.yaml` files, and packages them as ConfigMaps, ensuring all configuration changes are validated and up-to-date before merging:

1. **Prepare Helmfile Manifests**
   - The contents of the `opendesk-helmfiles` directory are copied from the official OpenDesk repository: [opencode.de/bmi/opendesk/deployment/opendesk/-/tree/develop/helmfile](https://gitlab.opencode.de/bmi/opendesk/deployment/opendesk/-/tree/develop/helmfile?ref_type=heads).
   - Ensure you have the required environment variables set, such as `DOMAIN`, `ENV`, and `NAMESPACE` as needed.

2. **Generate values.yaml files**
    - Run:
    ```sh
    make values
    ```
    - This executes `helmfile write-values` for each app, generating values files in `opendesk-helmfiles/helmfile/apps/*/out/`.

3. **Package ConfigMaps**
    - Run:
    ```sh
    make configmaps
    ```
    - This packages the generated values files as Kubernetes ConfigMaps in `ocm/values-config-maps/`.

#### Build and Transfer OCM Components

OCM component versions are built and transferred using the GitHub workflow `.github/workflows/ocm-component-check.yml`. The workflow uses the OCM CLI to add components and transfer them to the configured OCI registry:

1. **Add OCM Components**
    - The workflow runs:
     ```sh
     ocm add components --create --file ./ctf component-constructor.yaml artifactVersion=<VERSION>
     ```

2. **Transfer to OCI Registry**
    - The workflow runs:
    ```sh
    ocm transfer ctf --overwrite ./ctf <OCI_REGISTRY>
    ```
    - Authentication to the registry is required.

### Deploying OpenDesk using OCM and KRO

#### Prerequisites

- A Kubernetes cluster (v1.25 or newer recommended)
- [FluxCD](https://fluxcd.io/docs/installation/) installed
- [Kro](https://kro.run/docs/getting-started/Installation) installed
- Access to an OCI-compatible container registry for storing OCM components
- Required Kubernetes secrets:
  - `github-pull-secret`: for accessing private GitHub repositories (if needed)
  - `ocm-secret`: credentials for accessing the OCI registry containing OCM artifacts
- A valid TLS certificate for your domain, provided as a Kubernetes secret (see your ingress controller documentation)

#### Bootstrapping the Deployment

1. **Install Flux and Controllers**
    - Install Flux and ensure the OCM K8s Toolkit controller and KRO are deployed in your cluster.

2. **Create Required Secrets**
    - Ensure the required secrets (`github-pull-secret`, `ocm-secret`, and your TLS certificate secret) are present in the target namespace before starting the deployment.

3. **Apply Flux Manifests**
    - Bootstrap the deployment by applying the manifests in the `flux/` directory:
      ```sh
      kubectl apply -f flux/
      ```
    - This sets up the GitOps pipeline and prepares the cluster for OCM-based deployments, and KRO resource orchestration.

4. **Trigger Application Deployment**
    - The deployment is managed by Flux and KRO. Once the bootstrap resources and secrets are in place, the system will automatically deploy and manage the OpenDesk components as defined in the OCM resources.

Monitor the status of your deployment using standard Kubernetes and Flux commands, such as `kubectl get kustomizations`, `kubectl get helmreleases`, and `kubectl get resourcegraphdefinitions`.

## Support, Feedback, Contributing

This project is open to feature requests/suggestions, bug reports etc. via [GitHub issues](https://github.com/platform-mesh/<your-project>/issues). Contribution and feedback are encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](CONTRIBUTING.md).

## Security / Disclosure
If you find any bug that may be a security problem, please follow our instructions at [in our security policy](https://github.com/platform-mesh/<your-project>/security/policy) on how to report it. Please do not create GitHub issues for security-related doubts or problems.

## Code of Conduct

We as members, contributors, and leaders pledge to make participation in our community a harassment-free experience for everyone. By participating in this project, you agree to abide by its [Code of Conduct](https://github.com/platform-mesh/.github/blob/main/CODE_OF_CONDUCT.md) at all times.

## Licensing

Copyright (20xx-)20xx SAP SE or an SAP affiliate company and <your-project> contributors. Please see our [LICENSE](LICENSE) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/platform-mesh/<your-project>).
