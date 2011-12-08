/**
Called from TinyMCEPlugin init, defined in FoswikiTiny.init

To make this work, the init topic is set like:
   * Set TINYMCEPLUGIN_INIT_TOPIC = %SYSTEMWEB%.BaseSkinTinyMCEPlugin

BaseSkinTinyMCEPlugin defines the init callback in init_instance_callback.
*/
function tinyMceInited() {
	if (!FoswikiTiny.init) {
		return;
	}
	var classes = ['mceEditor'];
	if (FoswikiTiny.init.skin) {
		classes.push(FoswikiTiny.init.skin + 'Skin');
	}
	if (FoswikiTiny.init.skin && FoswikiTiny.init.skin_variant) {
		classes.push(FoswikiTiny.init.skin + 'Skin' + FoswikiTiny.init.skin_variant.capitalize());
	}

	var $toolbar = jQuery('#topic_toolbargroup').parent().parent();
	var $new = jQuery('<div class="' + classes.join(' ') +  '">')
		.append(jQuery('<table style="width: 100%;">')
			.append($toolbar)
		);
	$new.appendTo('.foswikiContextual .foswikiContainer');
	
	if (jQuery) {
		jQuery('.foswikiContextual').removeClass('foswikiHidden');
	}
}

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}