# Lambda Configuration

This is the step-by-step procedure to create a lambda function for running XSpec tests.

## Create the Lambda Function 

1. Create a zip file containing at its root [runXSpecBash.sh](runXSpecBash.sh) and [bootstrap](bootstrap). 
2. Log into AWS and go to Lambda.
3. Click on Create Function and give it the function name `runXSpecBash`. Under Runtime: Custom Runtime select Provide your own runtime. Finally click on Create function.
3. Click on the function `runXSpecBash` and in Function Code -> Code entry type select Upload a zip file. Upload the zip file created in step 1.
4. Scroll down and in Basic settings adjust the values of Memory and Timeout according to your work load. For this example I recommend to change the memory to at least 512 MB and timeout to at least 2 minutes.


## Create the Layers

1. Retrieve the zip file containing the latest stable version of XSpec from [here](https://github.com/xspec/xspec/releases/latest) (scroll down and retrieve the zip file from Assets -> Source code (zip)). Unzip the file to a local directory, go into the local directory and re-zip all the files from there.
2. Retrieve the jar file of your preferred version of Saxon HE from [Maven Central](http://central.maven.org/maven2/net/sf/saxon/Saxon-HE) and zip it in a file. Again, make sure that the zip file contains the .jar file at its root (do not use sub-folders). 
3. Log into AWS and go to Lambda -> Layers -> Create a Layer.
4. Upload the zip file containing XSpec and click on create. Take note of the value in Version ARN. 
5. Repeat point 4 for the zip file with Saxon HE.
6. Create another layer for bash following [these instructions](https://github.com/gkrizek/bash-lambda-layer). Set up the ARN according to your region (e.g. `arn:aws:lambda:us-east-1:744348701589:layer:bash:5`).
7. Go to Lambda -> Function, select the function `runXSpecBash` and click on Layers. Click on Add a layer. Select Provide a layer version ARN, copy the version ARN from the previous steps, click on Add and then click on Save. Repeat the same procedure for Saxon and bash.
8. Set the trigger for the lambda function. In Add trigger select S3 and in Bucket select the S3 bucket where your GitHub code is stored. 
9. Finally, click on Add and then Save.
10. To store the HTML reports of the XSpec tests you need to create a new S3 bucket. In the lambda function this S3 bucket is named `git2s3-report`. 
11. Make sure to assign permissions in the IAM role of the lambda function in order to access all the relevant S3 buckets. In the lambda function these S3 buckets are named `git2s3-outputbucket-16o2w1dtk7ddf` and  `git2s3-report`. You can start by giving your lambda function's IAM role full access to these S3 buckets. After testing that it works, tidy up the permissions of the IAM role in order to restrict access (e.g. read only access to `git2s3-outputbucket-16o2w1dtk7ddf` and write access to `git2s3-report`).
12. To send an email to users in case of a failing test, set up an SNS topic and assign permissions to access SNS to the IAM role of the lambda function. Again, you can start by assigning the IAM policy `SNSFullAccess` to the IAM role and restrict the permissions afterwards.


## Test the lambda function

1. Push a dummy commit that breaks the test suite. To get started you can use and modify the code examples in the [xslt](https://github.com/cirulls/markupuk2019/tree/master/xslt) and [xspec](https://github.com/cirulls/markupuk2019/tree/master/xspec) folders.
2. Check that the lambda function has been triggered. If not, go to Lambda -> Monitoring and check the CloudWatch logs. 
3. Check that the S3 bucket with the HTML reports has been updated and that a SNS notification has been sent. If not, check the CloudWatch logs to see what happened.
