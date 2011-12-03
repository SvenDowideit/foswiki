jQuery(document).ready(function($) {
	
	$('input.foswikiFocus').livequery(function() {
		$(this).focus();
	});
	
	var INITIAL_TOPIC_ACTIONS_Y;
	
	// stick topic action to top
	var offset = $('.foswikiTopicActions').offset();
	INITIAL_TOPIC_ACTIONS_Y = offset.top;
	var $foswikiTopicActions = $('.foswikiTopicActions');
	var $body = $('body');
	var hasFixedTopBar = 0;
	
	$(window).scroll(function() {
    	if ($(window).scrollTop() >= INITIAL_TOPIC_ACTIONS_Y) {
    		if (!hasFixedTopBar) {
	        	$body.addClass('foswikiFixedTopBar');
    	    	hasFixedTopBar = 1;
    	    }
		} else {
			if (hasFixedTopBar) {
				$body.removeClass('foswikiFixedTopBar');
				hasFixedTopBar = 0;
			}
		}
	});

/*
	$(window).scroll(function() {
    	if ($(window).scrollTop() >= INITIAL_TOPIC_ACTIONS_Y) {
        	$foswikiTopicActions.css({
        		position: 'fixed',
        		top: 0
        	});
		} else {
			$foswikiTopicActions.css({
				position: 'relative',
				top: 0
			});
		}
	});
*/
	var SCROLL_DURATION = 250;
	var SCROLL_TOP = 20;
	if (INITIAL_TOPIC_ACTIONS_Y !== undefined) {
		SCROLL_TOP = INITIAL_TOPIC_ACTIONS_Y + 20;
	}
	var scrollOpts = {
		reset: true,
		lazy: true,
		hash: true,
		duration: SCROLL_DURATION,
		axis: 'y',
		offset: { top:(-SCROLL_TOP), left:0 },
		easing: 'swing'
	};
	$('a').localScroll(scrollOpts);

	// also scroll on page load
	var anchor = getAnchor();
	if (anchor) {
		var $target = $('a[name=' + anchor + ']');
		if ($target.length === 0) {
			$target = $('#' + anchor);
		}
		if ($target.length !== 0) {
			$('body').scrollTo( $target, SCROLL_DURATION, scrollOpts );
		}
	}

});



function getAnchor( url ) {
	url = url || location.href;
	return url.replace( /^[^#]*#?!?(.*)$/, '$1' );
};