$( function( ) {
  var sbsPages = $( ".sbs-pages" );
  
  if ( sbsPages.length ) {
    var page;
    if ( window.location.hash ) {
      var hashParts = window.location.hash.split( '/' );
      if ( $.isNumeric( hashParts[ 1 ] ) ) {
        page = parseInt( hashParts[ 1 ] );
      }

    }
    sbsPages.turn( {
      width: 1000,
      height: 800,
      page: page
    } );
  }
} );
