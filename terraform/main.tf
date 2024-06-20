name: Build and Deploy .NET App with Terraform

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Terraform Init
        working-directory: ./terraform
        run: terraform init

      - name: Terraform Apply
        working-directory: ./terraform
        run: terraform apply -auto-approve
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

      - name: Output Azure App Service Name
        id: output
        working-directory: ./terraform
        run: |
          echo "::set-output name=app_service_name::$(terraform output -raw app_service_name)"

  build:
    runs-on: windows-latest
    needs: terraform

    steps:
      - uses: actions/checkout@v4

      - name: Set up .NET Core
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '6.0.x' # Altere para a versão desejada
          include-prerelease: true

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --configuration Release --no-restore

      - name: Publish
        run: dotnet publish --configuration Release --output ./output --no-build

      - name: Upload artifact for deployment job
        uses: actions/upload-artifact@v3
        with:
          name: dotnet-app
          path: ./output

  deploy:
    runs-on: windows-latest
    needs: [terraform, build]

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v3
        with:
          name: dotnet-app
          path: ./output

      - name: Setup Azure CLI
        uses: azure/setup-azure@v2
        with:
          azcliversion: 2.30.0

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Retrieve Azure App Service Publish Profile
        id: retrieve-profile
        run: |
          az webapp deployment list-publishing-profiles --resource-group tpontes-githubact-001 --name ${{ env.app_service_name }} --output json > publishProfile.json
          cat publishProfile.json

      - name: Set Publish Profile as Secret
        id: set-profile
        run: echo "AZUREAPPSERVICE_PUBLISHPROFILE=$(cat publishProfile.json)" >> $GITHUB_ENV

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.app_service_name }}
          slot-name: 'Production'
          publish-profile: ${{ env.AZUREAPPSERVICE_PUBLISHPROFILE }}
