$( function( ) {
  $(".edition-selector").on('change', function() {
      window.location.href = $(this).val();
  });

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
      width: 770,
      height: 600,
      page: page
    } );
  }

  var tabs = $( ".tab-menu" );
  var tabSelector = ".panel-menu a";
  var contentSelector = ".panel-content>section";
  var notesSelector = "#set-notes";
  var viewSelector = 'section.view';
  var bottomDrawerSelector = '.bottom.drawer';

  var $drawerHandle = $( '.drawer-handle' );

  tabs.find( tabSelector ).click( function( ) {
    var state = { };
    var id = $( this ).closest( ".tab-menu" ).attr( "id" );
    var idx = $( this ).parent().prevAll().length;

    state[ id ] = idx;
    $.bbq.pushState( state );
    return false;
  } );

  /* Setup drawers */
  $drawerHandle.click(function () {
    $('#interactive-image-panel').toggleClass('collapsed');
  } );

  if ( window.sessionStorage && window.sessionStorage.getItem( 'seenDrawer' ) ) {
    $drawerHandle.closest( notesSelector ).addClass( 'collapsed' );
  } else {
    setTimeout( function( ) {
      // show the notes for 2s to let the user know they exist
      // then hide them
      $drawerHandle.find('[data-drawer="' + notesSelector + '"]').click( );
      window.sessionStorage.setItem( 'seenDrawer', 'true' );
    }, 2000 );
  }

  setTimeout( function( ) {
    // enable drawer transitions only after initial setup
    $( bottomDrawerSelector ).addClass( 'bottom-drawer-transitions' );
  }, 33 );


  $( window ).on( "hashchange", function( e ) {
    tabs.each( function( ) {
      var idx = $.bbq.getState( this.id, true ) || 0;

      $( this ).find( tabSelector ).removeClass( "selected" ).eq( idx ).addClass( "selected" );
      $( this ).find( contentSelector ).hide( ).eq( idx ).show( );
    } );
  } );

  $( window ).trigger( "hashchange" );

    $("#no-edits").click(function () {
        $(".stanza").toggleClass("no-edits");
    });


    $("#linebreak-emily").click(function () {
        $(".stanza").toggleClass("linebreak-emily");
    });

  $( '.new_note,.edit_note' ).on( 'ajax:success', function( ) {
    var d = new Date();
    $( '.note-save-result' ).css('display', 'inline').text( 'Saved' ).delay(1000).fadeOut(1000);
  } );
} );
