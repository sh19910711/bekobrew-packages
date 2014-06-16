.PHONY: test

test:
	find test/ -name test_*.sh -exec bash {} \;
