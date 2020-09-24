$( function( ) {
  $('form#search-works').on('ajax:success', function(e, data) {
      $('.search-works-results').replaceWith(data);
  });

  if (window.sessionStorage && window.sessionStorage.getItem('search-works-options-toggle') === 'open') {
    $('.search-works-options, .search-works-options-toggle').addClass('open');
  }

  $( '.search-works-options-toggle' ).click( function( e ) {
    var toggle = $('.search-works-options, .search-works-options-toggle').toggleClass('open');
    if (window.sessionStorage) {
      window.sessionStorage.setItem('search-works-options-toggle', toggle.hasClass('open') ? 'open' : '');
    }
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
      $.modal(data, {
        close: true
      });
    });

    return false;
  } );


} );
