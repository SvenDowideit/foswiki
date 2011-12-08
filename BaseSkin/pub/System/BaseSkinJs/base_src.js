jQuery(document).ready(function($) {
	
	function smoothScroll() {
		var offset = $('.foswikiTopicActions').offset();
		var topicActionsY = offset.top;
		
		var SCROLL_DURATION = 250;
		var SCROLL_TOP = 20;
		if (topicActionsY !== undefined) {
			SCROLL_TOP = topicActionsY + 35;
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
	}
	
	function fixTopicActions(resize) {
		
		var $body = $('body');
		var $fixed = $('.foswikiFixed');
		if (!$fixed.length) {
			return;
		}
		var $topicActions = $('.foswikiFixed .foswikiTopicActions');
		if (!$topicActions.length) {
			return;
		}
		var $topic = $('.foswikiMain');
		
		var offset = $fixed.offset();
		var topicActionsY = offset.top;

		var orgPadding = parseInt($topicActions.css('padding-top'), 10);
		var topicPadding = parseInt($topic.css('padding-top'), 10);
	
		var MIN_PADDING = 4, hasFixed = 0, p, d, ival;
		
		var handleScroll = function() {

			var scrollTop = $(window).scrollTop();
			if (scrollTop >= topicActionsY) {
				if (!hasFixed) {
					$body.addClass('foswikiHasFixed');
					var height = $fixed.outerHeight();
					$topic.css('padding-top', topicPadding + height);
					hasFixed = 1;
				}
	
			} else {
				if (hasFixed) {
					$body.removeClass('foswikiHasFixed');
					hasFixed = 0;
					$topic.css('padding-top', topicPadding);
				}
			}
			
			if (resize) {
				p = orgPadding + 0.5 * (topicActionsY - scrollTop);
				if (p < MIN_PADDING ) {
					p = MIN_PADDING;
				} else if (p > orgPadding) {
					p = orgPadding;
				}
				if (d !== p) {
					d = p;
					$topicActions.css('padding-top', d);
					$topicActions.css('padding-bottom', d);
				}
			}
		};
		
		var handleScrollEvent = function() {
			clearTimeout(ival);
			ival = setTimeout(function() {
				handleScroll();
			}, 5);
		};
		
		$(window).scroll(handleScrollEvent);
	}
		
	function getAnchor( url ) {
		url = url || location.href;
		return url.replace( /^[^#]*#?!?(.*)$/, '$1' );
	}
	$('input.foswikiFocus').livequery(function() {
		$(this).focus();
	});
	
	smoothScroll();
	fixTopicActions(false);

});