/* 

Output file to highlight customized outputs that are useful 
(compared to the hundreds of attributes Terraform stores)

To see the output after the apply, use the command: "terraform output"

Note: Since we're using the official VPC and sg modules, you can NOT
create your own outputs for those modules, unless you create them as 
outputs for a new module (and nest these modules within)

 */

output "cluster_size" {
  value = length(aws_instance.cluster_master) + length(aws_instance.cluster_workers)
}

