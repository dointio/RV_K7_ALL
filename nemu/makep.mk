myprint_%:
	@echo '  $*=$($*)'
	@echo '  type = $(origin $*)'
	@echo '  origin_val = $(value $*)'
	@echo '  feature = $(flavor $*)'