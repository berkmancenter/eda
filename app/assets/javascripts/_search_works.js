$( function( ) {
  $( '.search-works-options a' ).click( function( e ) {
    $( '.search-works-options' ).toggleClass( 'open' );
    return false;
  } );

  $('.alphabet-list a').on('click', function(e) {
    e.preventDefault();
    $.get($(this).attr('href'), function(data) {
      $(e.target).closest('section').find('.alphabet-results').html(data);
    });
  });

  $('.alphabet-results').on( 'click', 'a', function(e) {
    e.preventDefault();

    $.get($(this).attr('href'), function(data) {
      $(e.target).closest('section').find('.alphabet-word').html(data);
    });

    return false;
  } );


} );
