.PHONY: setup lint format test build tf-init tf-plan tf-apply destroy clean help

TF_DIR := infra/terraform

help: ## List available targets
	@grep -E "^[a-z-]+:.*##" $(MAKEFILE_LIST) | sed "s/:.*##/ -/"

setup: ## Install dependencies and git hooks
	poetry install --with dev,test,local
	poetry run pre-commit install

lint: ## Run all pre-commit checks, then mypy
	poetry run pre-commit run --all-files

format: ## Auto-format code
	poetry run ruff check --fix .
	poetry run black .

test: ## Run tests with coverage
	poetry run pytest --cov --cov-report=term-missing

build: ## Package the Lambda into build/ (implemented in Phase 4)
	@echo "Lambda packaging is added in Phase 4"

tf-init: ## terraform init
	terraform -chdir=$(TF_DIR) init

tf-plan: ## terraform plan (preview only, changes nothing)
	terraform -chdir=$(TF_DIR) plan

tf-apply: ## terraform apply (creates paid AWS resources)
	@read -p "This creates AWS resources that cost money. Type yes to continue: " ans; [ "$$ans" = "yes" ]
	terraform -chdir=$(TF_DIR) apply

destroy: ## terraform destroy (deletes everything)
	@read -p "This deletes ALL project resources. Type yes to continue: " ans; [ "$$ans" = "yes" ]
	terraform -chdir=$(TF_DIR) destroy

clean: ## Remove local build artifacts
	rm -rf build dist .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage
