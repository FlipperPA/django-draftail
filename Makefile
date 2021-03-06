.PHONY: clean-pyc init help test-ci
.DEFAULT_GOAL := help

help: ## See what commands are available.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-15s\033[0m # %s\n", $$1, $$2}'

init: clean-pyc ## Install dependencies and initialise for development.
	./.githooks/deploy.sh
	pip install --upgrade pip setuptools twine
	pip install -r requirements.txt
	npm install

lint: ## Lint the project.
	black --check **/*.py
	flake8 **/*.py
	isort --check-only --diff --recursive **/*.py
	npm run lint

format: ## Format project files.
	isort --recursive *.py **/*.py
	black **/*.py
	npm run format

test: ## Test the project.
	python -m unittest discover

test-watch: ## Restarts the tests whenever a file changes.
	nodemon -q -e py -w tests -w draftail  -x "clear && make test -s || true"

test-coverage: ## Run the tests while generating test coverage data.
	coverage run -m unittest discover && coverage report && coverage html

test-ci: ## Continuous integration test suite.
	tox
	npm run test:ci

clean-pyc: ## Remove Python file artifacts.
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

sdist: ## Builds package version
	rm dist/* ; python setup.py sdist

publish: sdist ## Publishes a new version to pypi.
	twine upload dist/* && echo 'Success! Go to https://pypi.org/project/django-draftail/ and check that all is well.'

publish-test: sdist ## Publishes a new version to test pypi.
	twine upload --repository-url https://test.pypi.org/legacy/ dist/* && echo 'Success! Go to https://test.pypi.org/project/django-draftail/ and check that all is well.'
