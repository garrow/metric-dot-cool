TEMPLATE_FILES:=static/*.*

build: regenerate_reactor_custom_html
	echo "CLEAN"
	rm _site/* || echo "Nothing to delete"
	echo "COPY TEMPLATES"
	cp  $(TEMPLATE_FILES) _site
	echo "BUILD"
	elm make frontend/Main.elm --output _site/index.js
	node --check _site/index.js
	terminal-notifier -message "Build Complete $(date "+%H:%M:%S")" -title "Metric.cool.build" -group cool.metric.build.local
	sleep 1
	terminal-notifier -remove cool.metric.build.local



regenerate_reactor_custom_html:
	cp  static/index.html reactor.html
	sed -i '' -e  's/index.js/\/_compile\/frontend\/Main.elm/g' reactor.html

configure_s3:
	aws configure --profile $DEPLOY_PROFILE

# aws s3 sync _site s3://metric.cool/ --region us-east-1 --profile metric.cool.deployer

deploy:
	aws s3 sync _site "${S3_BUCKET_NAME}" --region "${S3_REGION}"  --profile "${S3_DEPLOY_PROFILE}"

invalidate_cache:
	aws cloudfront create-invalidation --distribution-id "${CDN_DISTRIBUTION_ID}" --paths "/*"	--profile "${S3_DEPLOY_PROFILE}"
