// Optional: remote state backend (S3 + DynamoDB).
// terraform {
//   backend "s3" {
//     bucket         = "innovatemart-terraform-state"
//     key            = "project-bedrock/infra.tfstate"
//     region         = "eu-west-1"
//     dynamodb_table = "innovatemart-terraform-locks"
//     encrypt        = true
//   }
// }
