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

  var interactiveImagePanel = $( '#interactive-image-panel' );
  var tabs = $( ".tab-menu" );
  var tabSelector = ".panel-menu a";
  var contentSelector = ".panel-content>section";
  var notesSelector = "#set-notes";
  var viewSelector = 'section.view';
  var bottomDrawerSelector = '.bottom.drawer';

  var $drawerHandle = $( '.left.drawer-handle,.right.drawer-handle' );

  tabs.find( tabSelector ).click( function( ) {
    var state = { };
    var id = $( this ).closest( ".tab-menu" ).attr( "id" );
    var idx = $( this ).parent().prevAll().length;

    state[ id ] = idx;
    $.bbq.pushState( state );
    return false;
  } );

  /* Setup drawers */
  $drawerHandle.click( function( ) {
    var drawerId = $(this).data('drawer');
    var collapsed = $('#' + drawerId).toggleClass( 'collapsed' ).hasClass( 'collapsed' );
    $(viewSelector).toggleClass( 'minus-' + drawerId );

    if ( window.sessionStorage ) {
      window.sessionStorage.setItem( drawerId + '-collapsed',  collapsed );
    }
  } );
  
  /* Setup bottom drawer */
  $( bottomDrawerSelector + ' ' + '.drawer-handle' ).click(function () {
    var drawerContentSelector = '#' + $( this ).data( 'drawer' );

    var changeDrawerContent = !$( drawerContentSelector ).is( ':visible' );
    var drawerOpen = !interactiveImagePanel.hasClass( 'collapsed' );
    var toggleDrawer = !drawerOpen || !changeDrawerContent;

    if ( toggleDrawer ) {
      interactiveImagePanel.toggleClass( 'collapsed' );
    }

    if ( changeDrawerContent ) {
      $( '.image-drawer-tabs a' ).removeClass( 'hidden' ).not( this ).addClass( 'hidden' );
      $( '.image-drawer-content>div' ).removeClass( 'hidden' ).not( drawerContentSelector ).addClass( 'hidden' );
    }
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
      var drawerId = this.id;
      var idx = $.bbq.getState( drawerId, true );

      if ( window.sessionStorage && window.sessionStorage.getItem( drawerId + '-collapsed' ) !== null ) {
        // show the drawer if told to do so in sessionStorage
        // overrides opening drawer based on panel selection below
        var collapsed = window.sessionStorage.getItem( drawerId + '-collapsed' ) === 'true';
        $('#' + drawerId).toggleClass( 'collapsed', collapsed );
        $(viewSelector).toggleClass( 'minus-' + drawerId, collapsed );
      } else {
        // show the drawer if it contains a selected tab
        if ($( this ).hasClass( 'collapsed' ) && typeof idx != 'undefined') {
          $(this).find('.drawer-handle').click();
        }
      }

      idx = idx || 0;

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
