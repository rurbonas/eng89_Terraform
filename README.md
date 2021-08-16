# IaC with Terraform

To create public/private keys in Git Bash
- Head over to your .ssh folder and create .pub and .pem keys
- `ssh-keygen -t rsa -b 2048 -v -f eng89_ron_ter`
- `mv eng89_ron_ter eng89_ron_ter.pem` to add the .pem extension
- `chmod 400 eng89_ron_ter.pem`
- `chmod 600 eng89_ron_ter.pub`

Import Public key to AWS
- Navigate to: EC2 >> Network & Security >> Key Pairs
- Actions >> Import key pair
- Name: `eng89_ron_ter`
- Browse and import the `eng89_ron_ter.pub` file
- Press `Import Key Pair` button

Now we can SSH into the newly created EC2 instance from our .ssh folder


...Work in progress