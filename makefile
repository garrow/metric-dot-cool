TEMPLATE_HTML:=static/*.html

#clean:
#	rm _site/*


#copy_templates:
#	cp  $(TEMPLATE_HTML) _site


build:
	echo "CLEAN"
	rm _site/*
	echo "COPY TEMPLATES"
	cp  $(TEMPLATE_HTML) _site
	echo "BUILD"
	elm-make frontend/Main.elm --output _site/index.js
	node --check _site/index.js

configure_s3:
	aws configure --profile metric.cool.deployer

deploy:
	aws s3 sync _site s3://metric.cool/ --region us-east-1 --profile metric.cool.deployer
