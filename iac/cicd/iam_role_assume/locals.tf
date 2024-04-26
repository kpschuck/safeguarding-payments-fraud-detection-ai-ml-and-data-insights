locals {
  region = (
    data.aws_region.this.name == element(keys(var.backend_bucket), 0)
    ? element(keys(var.backend_bucket), 1) : element(keys(var.backend_bucket), 0)
  )
  spf_gid = (var.spf_gid == null ? (
    data.aws_region.this.name == element(keys(var.backend_bucket), 0)
    ? random_id.this.hex : data.terraform_remote_state.iam.0.outputs.spf_gid
  ) : var.spf_gid)
  ips = {
    for val in jsondecode(data.http.this.response_body)["prefixes"]: lower(val["service"]) => val... if (
      lower(val["service"]) == "codebuild" && (
        val["region"] == element(keys(var.backend_bucket), 0)
        || val["region"] == element(keys(var.backend_bucket), 1)
      )
    )
  }
  policy_ips  = local.ips["codebuild"].*.ip_prefix
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}