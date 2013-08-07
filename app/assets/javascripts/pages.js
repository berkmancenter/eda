$( function( ) {
  var tabs = $( ".tab-menu" );
  var tabSelector = ".panel-menu a";
  var contentSelector = ".panel-content>section";
  var notesSelector = ".work-notes";
  var drawerHandleSelector = '.drawer-handle';

  tabs.find( tabSelector ).click( function( ) {
    var state = { };
    var id = $( this ).closest( ".tab-menu" ).attr( "id" );
    var idx = $( this ).parent().prevAll().length;

    state[ id ] = idx;
    $.bbq.pushState( state );
    return false;
  } );

  /* Setup drawers */
  $( drawerHandleSelector ).click( function( ) {
    $( this ).closest( notesSelector ).toggleClass( 'collapsed' );
  } );

  setTimeout( function( ) {
    // show the notes for 2s to let the user know they exist
    // then hide them
    $( drawerHandleSelector ).click( );
  }, 2000 );


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

} );
