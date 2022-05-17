jQuery(document).ready(function($) {
	$('#ip2location-redirection-notice').click(function(e) {
		e.preventDefault();
		$.post(ajaxurl, { action: 'ip2location_redirection_dismiss_notice' });
	});
});