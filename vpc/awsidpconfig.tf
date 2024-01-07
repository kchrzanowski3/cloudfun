resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["cf23df2207d99a74fbe169e3eba035e633b65d94"]
}

#aws role says what users are authorized to access the role (github actions oidc)
resource "aws_iam_role" "github_action_oidc_role" {
  name = "github_action_oidc_role"

  assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub": "repo:$( local.repo.org )/( local.repo.project ):*"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
})
}

#aws policy says what actions can be performed for the OIDC github action that assumes the role above
resource "aws_iam_role_policy" "policy" {
    name  = "terraform-githubaction-oidc-policy"
    role = aws_iam_role.github_action_oidc_role.id
    
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action = [
            "*",
        ]
        Effect   = "Allow"
        Resource = "*"
        },
    ]
    })
  
}
