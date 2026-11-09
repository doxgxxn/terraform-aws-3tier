# bootstrap

CI가 돌기 전에 **한 번만** 로컬 관리자 자격증명으로 적용하는 최소 기반입니다.

만드는 것:

- **원격 상태 버킷** `t3t-tfstate-<account_id>` — 버저닝·암호화·퍼블릭 차단. 잠금은 DynamoDB 대신 Terraform 1.10+의 **S3 네이티브 lockfile**(`use_lockfile = true`)을 사용합니다.
- **GitHub OIDC 자격증명** — `token.actions.githubusercontent.com` IdP + `github-actions-terraform` 롤. 장기 액세스 키 없이 이 레포의 워크플로만 롤을 assume할 수 있습니다. IAM 권한은 `t3t-*` 롤 프리픽스로 스코프.

```bash
cd bootstrap
terraform init   # bootstrap 자체는 로컬 상태 (닭-달걀 문제)
terraform apply
```

적용 후 출력 2개를 GitHub 레포 변수(Settings → Secrets and variables → Actions → **Variables**)에 등록하면 CI의 plan/apply가 활성화됩니다:

| Output | Repository variable |
|---|---|
| `tf_state_bucket` | `TF_STATE_BUCKET` |
| `ci_role_arn` | `AWS_ROLE_ARN` |
