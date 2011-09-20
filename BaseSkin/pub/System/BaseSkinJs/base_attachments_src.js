jQuery(document).ready(function() {

	function sort($el, sort) {
		
		// TODO:

		// sort direction feedback
		// put sort plugin in separate plugin and give author due copyright
		
		var direction = $el.attr('data-sort-direction');
		if (direction === undefined) {
			direction = 1;
		}
		if (sort === 'data-date' || sort === 'data-rev') {
			// latest on top
			direction = -direction;
		}
		var compare;
		var type = 'string';
		if (sort === 'data-size' || sort === 'data-date') {
			// number
			comparator = function(a, b) {
				return parseInt(jQuery(a).attr(sort), 10) > parseInt(jQuery(b).attr(sort), 10) ? direction : -direction;
			};
		} else {
			// string
			comparator = function(a, b) {
				return jQuery(a).attr(sort) > jQuery(b).attr(sort) ? direction : -direction;
			};
		}
		// find parent with class 'foswikiAttachments
		var $attachments = $el.parents('.foswikiAttachments');
		
		jQuery('.foswikiAttachment', $attachments).sortElements(comparator);
		/*
		direction = -direction;
		$el.attr('data-sort-direction', direction);
		*/
		return false;
	}
	
	// find currently selected value and sort
	jQuery('select.foswikiSort').livequery(function() {
		sort(jQuery(this), jQuery(this).val());
		return false;
	});
	
	jQuery('select.foswikiSort').livequery('change', function() {
		sort(jQuery(this), jQuery(this).val());
		return false;
	});
	
	jQuery('a.foswikiSort').livequery('click', function() {
		sort(jQuery(this), jQuery(this).attr('data-sort'));
		return false;
	});
	
	function toggleAttachmentDetails($set, doHide) {
			
		var hiding;
		if (doHide !== undefined) {
			hiding = doHide;
		} else {
			hiding = $set.attr('data-hidedetails');
			if (hiding === undefined) {
				hiding = 1;
			}
		}
		
		// find parent with class 'foswikiAttachments
		var $attachments = jQuery('.foswikiAttachments');
		console.log("$attachments=");
		console.log($attachments);

		if (hiding) {
			$attachments.addClass('bsHideDetails');
		} else {
			$attachments.removeClass('bsHideDetails');
		}
		$set.attr('data-hidedetails', hiding);
	}
	
	jQuery('a.jqButtonSet').livequery(function() {		
		toggleAttachmentDetails(jQuery(this));
		return false;
	});
	
	jQuery('a.bsShow').livequery('click', function() {
		// find set element
		var $set = jQuery(this).parents('.jqButtonSet,.foswikiButtonSet');
		toggleAttachmentDetails($set, 0);
		return false;
	});
	
	jQuery('a.bsHide').livequery('click', function() {
		// find set element
		var $set = jQuery(this).parents('.jqButtonSet,.foswikiButtonSet');
		toggleAttachmentDetails($set, 1);
		return false;
	});
	
	jQuery('input.foswikiFocus').livequery(function() {
			jQuery(this).focus();
		}
	);
});



/**
 * jQuery.fn.sortElements
 * --------------
 * @author James Padolsey (http://james.padolsey.com)
 * @version 0.11
 * @updated 18-MAR-2010
 * --------------
 * @param Function comparator:
 *   Exactly the same behaviour as [1,2,3].sort(comparator)
 *   
 * @param Function getSortable
 *   A function that should return the element that is
 *   to be sorted. The comparator will run on the
 *   current collection, but you may want the actual
 *   resulting sort to occur on a parent or another
 *   associated element.
 *   
 *   E.g. $('td').sortElements(comparator, function(){
 *      return this.parentNode; 
 *   })
 *   
 *   The <td>'s parent (<tr>) will be sorted instead
 *   of the <td> itself.
 */
jQuery.fn.sortElements = (function(){
    
    var sort = [].sort;
    
    return function(comparator, getSortable) {
        
        getSortable = getSortable || function(){return this;};
        
        var placements = this.map(function(){
            
            var sortElement = getSortable.call(this),
                parentNode = sortElement.parentNode,
                
                // Since the element itself will change position, we have
                // to have some way of storing it's original position in
                // the DOM. The easiest way is to have a 'flag' node:
                nextSibling = parentNode.insertBefore(
                    document.createTextNode(''),
                    sortElement.nextSibling
                );
            
            return function() {
                
                if (parentNode === this) {
                    throw new Error(
                        "You can't sort elements if any one is a descendant of another."
                    );
                }
                
                // Insert before flag:
                parentNode.insertBefore(this, nextSibling);
                // Remove flag:
                parentNode.removeChild(nextSibling);
                
            };
            
        });
       
        return sort.call(this, comparator).each(function(i){
            placements[i].call(getSortable.call(this));
        });
        
    };
    
})();