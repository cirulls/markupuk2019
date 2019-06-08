# Lambda Configuration

This is the step-by-step procedure to create a lambda function for running XSpec tests.

## Create the Lambda Function 

1. Create a zip file containing at its root [runXSpecBash.sh](runXSpecBash.sh) and [bootstrap](bootstrap). 
2. Log into AWS and go to Lambda.
3. Click on Create Function and give it the function name `runXSpecBash`. Under Runtime: Custom Runtime select Provide your own runtime. Finally click on Create function.
3. Click on the function `runXSpecBash` and in function code -> Code entry type select upload a zip file. Upload the zip file created previously.
4. Change the memory settings to 2 minutes and click on Save.


## Create the Layers

1. Retrieve the zip file containing the latest stable version of XSpec from [here](https://github.com/xspec/xspec/releases/latest) (scroll down and retrieve the zip file from Assets -> Source code (zip)). Unzip the file to a local directory, go into the local directory and re-zip all the files from there. 
2. Retrieve the jar file of your preferred version of Saxon HE from [Maven Central](http://central.maven.org/maven2/net/sf/saxon/Saxon-HE) and zip it in a file. Again, make sure that the zip file contains the .jar file at its root (do not use sub-folders). 
3. Log into AWS and go to Lambda -> Layers -> Create a Layer.
4. Upload the zip file with xspec and  click on create. Take note of the value in Version ARN. 
5. Repeat point 4 for the zip file with Saxon HE.
6. Create another layer for bash following [these instructions](https://github.com/gkrizek/bash-lambda-layer). Set up the ARN according to your region (e.g. `arn:aws:lambda:us-east-1:744348701589:layer:bash:5`).
7. Go to Lambda -> Function, select the function `runXSpecBash` and click on Layers. Click on Add a layer. Select Provide a layer version ARN, copy the version ARN from the previous steps, click on Add and then click on Save. Repeat the same procedure for Saxon and bash.
8. Set the trigger for the lambda function. In Add trigger select S3 and in Bucket select the S3 bucket where you want to store your the output of the XSpec reports. You may need to create this bucket in S3 first. 
9. Finally, click on Add and then Save.
