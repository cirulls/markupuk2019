# CloudFormation Configuration

The CloudFormation configuration follows the [Quick Start guide](https://aws-quickstart.s3.amazonaws.com/quickstart-git2s3/doc/git-to-amazon-s3-using-webhooks.pdf) published by AWS and its [CloudFormation template](https://github.com/aws-quickstart/quickstart-git2s3/blob/master/templates/git2s3.template). I recommend to read the guide before reading any further. 

Here below I am describing the step-by-step procedure I follow to set this up and the changes I've made.

1. Go to CloudFormation -> Create a new Stack, then Choose a template -> Upload a template to Amazon S3 and upload this [CloudFormation template](cloudformation/git2s3.template). This is basically the same CloudFormation template provided in the Quick Start guide but I added few IP addresses related to GitHub webhooks (useful if you're integrating this with GitHub). Please check that the three GitHub hooks IP addresses are still valid [here](https://api.github.com/meta) (GitHub changes them for time to time). If not, add the new ones under `AllowedIps` in the CloudFormation template.  
2. Put a name for Stack Name and leave the rest as it is. 
3. Click on Next then thick the box to allow to create a role, click OK and wait for the CloudFormation template to complete. 
4. Click on Output and copy the value of `GitPullWebHookApi` and `PublicSSHKey`. You will need these values later on to create the GitHub webhook. 
5. Create the webhook in GitHub following [these instructions](https://developer.github.com/webhooks/creating). Use the value of `GitPullWebHookApi` as Payload URL. At the end take note of the secret as you will need it later.
6. Add the public key in your GitHub repo under Settings -> Deploy keys. Use the value of `PublicSSHKey` retrieved previously.
7. Go back to CloudFormation and modify the value of parameter ApiSecret. Use the secret set up in the GitHub webhook and update the CloudFormation stack. 
