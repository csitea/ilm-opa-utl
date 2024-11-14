# # usage: include it in your Makefile
# include <<file-path>>
#
# usage:
# make zip_me
# 

.ONESHELL: # Applies to every targets in the file!

.PHONY: zip_me ## @-> 99.01 zip the whole project without the .git dir
zip_me:
	@clear
	-rm -v ../$(PROJ).zip ; zip -r ../$(PROJ).zip  . -x '*.git*' -x '*node_modules*'
	@sleep 1
	@clear
	@echo done check
	@echo $(PWD)/../$(PROJ).zip

.ONESHELL: # Applies to every targets in the file!

.PHONY: zip_node_modules ## @-> 99.01 zip the whole project without the .git dir
zip_node_modules:
	@clear
	-rm -v ../$(PROJ)-node_modules.$$(git rev-parse --abbrev-ref HEAD).zip ; zip -r ../$(PROJ)-node_modules.$$(git rev-parse --abbrev-ref HEAD).zip  node_modules -x '*.git*'
	@sleep 1
	@clear
	@echo done check
	@echo $(PWD)/../$(PROJ)-node_modules.$$(git rev-parse --abbrev-ref HEAD).zip
