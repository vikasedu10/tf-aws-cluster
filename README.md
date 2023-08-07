# EKS Cluster Provisioning with Terraform

This Terraform script provisions an Amazon EKS cluster in either the production or development environment. The script handles all the necessary configurations and infrastructure setup required for a robust EKS cluster.

## Prerequisites

- Terraform 0.12.x or later
- AWS CLI configured with the necessary permissions
- Kubernetes CLI (kubectl)

## Usage

1. **Set Environment Variables:** Depending on the target environment, set the appropriate environment variables.

    For Production:
    ```bash
    export TF_VAR_environment=production
    ```

    For Development:
    ```bash
    export TF_VAR_environment=development
    ```

    Defaults are taken from variables.tf.

2. **Set AWS credentials:** Configure AWS credentials for your choosen profile
    ```bash
    aws configure
    ```

2. **Initialize Terraform:** Navigate to the Terraform directory and run:
    ```bash
    terraform init
    ```

3. **Plan the Deployment:** To see the execution plan, run:
    ```bash
    terraform plan
    ```

4. **Apply the Changes:** To apply the changes and create the EKS cluster, run:
    ```bash
    terraform apply
    ```

    Confirm with `yes` when prompted.

5. **Configure kubectl:** After the script execution is successful, you may need to configure kubectl with the newly created EKS cluster. You can use the AWS CLI command:
    ```bash
    aws eks --region <region> update-kubeconfig --name <cluster_name>
    ```

6. **Destroy the Cluster (Optional):** If you need to tear down the cluster, run:
    ```bash
    terraform destroy
    ```

    Confirm with `yes` when prompted.

## Variables

The following variables can be customized in the `variables.tf` file or by using environment variables:

- `environment`: Target environment (`prod` or `dev`).
- `region`: AWS region for the resources.
- `cluster_name`: Name of the EKS cluster.
- `node_count`: Number of worker nodes.
- `vpc_cidr_block`: VPC CIDR range.
- `instance_type`: Machine type.
- `min_node_count`: Minimum node count.
- `max_node_count`: Maximum node count.

## Outputs

After successful execution, the following outputs will be provided module-wise:

- `cluster_endpoint`: Endpoint for the EKS cluster.
- `cluster_security_group`: Cluster's security group ID.

## Contributing

Feel free to raise issues or pull requests if you want to contribute to this project.

## License

This code is released under the MIT License. See `LICENSE.md` for more details.
