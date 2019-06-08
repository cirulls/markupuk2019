function handler () {
    set -e 
    
    EVENT_DATA=$1

    aws s3 cp s3://git2s3-outputbucket-16o2w1dtk7ddf/cirulls/markupuk-demo/branch/master/cirulls_markupuk-demo_branch_master.zip /tmp 
    unzip /tmp/cirulls_markupuk-demo_branch_master.zip -d /tmp/code 
    export SAXON_CP=/opt/saxon9he.jar
    export TEST_DIR=/tmp
    
    cd /tmp/code/xspec
    
    for xspectest in *.xspec
    do 
        if test "${xspectest:0:10}" = "schematron"; then
            /opt/bin/xspec.sh -s $xspectest &> /tmp/result.log;
        else                                                                                                                                                               
            /opt/bin/xspec.sh $xspectest &> /tmp/result.log;
        fi
    
        aws s3 cp /tmp/$(basename $xspectest .xspec)-result.html s3://git2s3-report >&2
        
        if grep -q ".*failed:\s[1-9]" /tmp/result.log || grep -q -E "\*+\sError\s(.*Schematron.*|(running|compiling)\sthe\stest\ssuite)" /tmp/result.log;
            then
                echo "FAILED: $xspectest" >&2 
                echo "FAILED: $xspectest Full report at s3://git2s3-report/$(basename $xspectest .xspec)-result.html" >> /tmp/result.log
                aws sns publish --topic-arn "arn:aws:sns:us-east-1:570558891272:sandro" --subject "XSpec test suite failed" --message file:///tmp/result.log
                exit 1;
            else echo "OK: $xspectest" >&2 
        fi  
    done
}
