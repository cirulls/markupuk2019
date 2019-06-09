function handler () {
    set -e 
    
    EVENT_DATA=$1

    # retrieve data from the GitHub S3 bucket (e.g. git2s3-outputbucket-16o2w1dtk7ddf)
    aws s3 cp s3://git2s3-outputbucket-16o2w1dtk7ddf/cirulls/markupuk-demo/branch/master/cirulls_markupuk-demo_branch_master.zip /tmp 
    # unzip the file
    unzip /tmp/cirulls_markupuk-demo_branch_master.zip -d /tmp/code 
    # set environment variables for XSpec
    export SAXON_CP=/opt/saxon9he.jar
    export TEST_DIR=/tmp
    
    cd /tmp/code/xspec
    # run .xspec tests in this folder   
    for xspectest in *.xspec
    do 
        if test "${xspectest:0:10}" = "schematron"; then
            /opt/bin/xspec.sh -s $xspectest &> /tmp/result.log;
        else                                                                                                                                                               
            /opt/bin/xspec.sh $xspectest &> /tmp/result.log;
        fi
        
        # store HTML report in an S3 bucket (e.g. git2s3-report)
        aws s3 cp /tmp/$(basename $xspectest .xspec)-result.html s3://git2s3-report >&2
       
        # check if a test failed 
        if grep -q ".*failed:\s[1-9]" /tmp/result.log || grep -q -E "\*+\sError\s(.*Schematron.*|(running|compiling)\sthe\stest\ssuite)" /tmp/result.log;
            then
                echo "FAILED: $xspectest" >&2 
                echo "FAILED: $xspectest Full report at s3://git2s3-report/$(basename $xspectest .xspec)-result.html" >> /tmp/result.log
                # Send SNS notification. Put the relevant values for <your_region>, <your_aws_account_id>, <your_sns_topic>
                aws sns publish --topic-arn "arn:aws:sns:<your_region>:<your_aws_account_id>:<your_sns_topic>" --subject "XSpec test suite failed" --message file:///tmp/result.log
                # stop the lambda function
                exit 1;
            else echo "OK: $xspectest" >&2 
        fi  
    done
}
