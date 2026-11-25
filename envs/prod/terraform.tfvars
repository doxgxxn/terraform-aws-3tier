region          = "ap-northeast-2"
name            = "t3t-prod"
vpc_cidr        = "10.20.0.0/16"
container_image = "public.ecr.aws/docker/library/nginx:stable-alpine"
container_port  = 80
desired_count   = 2
