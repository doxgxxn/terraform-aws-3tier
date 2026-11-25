region          = "ap-northeast-2"
name            = "t3t-dev"
vpc_cidr        = "10.10.0.0/16"
container_image = "public.ecr.aws/docker/library/nginx:stable-alpine"
container_port  = 80
desired_count   = 1
