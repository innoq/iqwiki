(function() {
	
	document.onkeypress = function (e) {

	/*		
			if (!e) {
			    e = window.event
			}
	*/		
//			alert( 'ljfhkdjhs' + e.charCode );

			if ( e.charCode == 99 ) {

// 				alert( "go to " + $( '#new_page_link' ).attr('href') );
				
				var the_link = $( '#new_page_link' );
//				document.location = the_link.attr('href');
				the_link.click();
			}
	};



	
}());


