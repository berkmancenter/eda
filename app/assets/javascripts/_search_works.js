$( function( ) {
  $('form#search-works').on('ajax:success', function(e, data) {
      $('.search-works-results').replaceWith(data);
  });
  $( '.search-works-options-toggle' ).click( function( e ) {
    $( '.search-works-options, .search-works-options-toggle' ).toggleClass( 'open' );
    return false;
  } );

  $('.alphabet-list a').on('click', function(e) {
    e.preventDefault();
    $.get($(this).attr('href'), function(data) {
      $(e.target).closest('section').find('.alphabet-results').html(data);
    });
  });

  $('.lexicon-results').on( 'click', 'a', function(e) {
    e.preventDefault();

    $.get($(this).attr('href'), function(data) {
      $.modal(data);
    });

    return false;
  } );


} );
