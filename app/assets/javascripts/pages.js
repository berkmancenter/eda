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
  $( notesSelector ).addClass( "bottom drawer" ).css('display', 'none').find('h2').appendTo(drawerHandleSelector);
  $( drawerHandleSelector ).addClass('visible').on('click', function() {
      if ($(this).parent().get(0) == $(notesSelector).get(0)) {
        $(this).insertBefore($(notesSelector));
      } else {
        $(this).prependTo($(notesSelector));
      }
      $( $(this).data('drawer') ).slideToggle();
  });

  /* Setup nav drawer */
  //$( navSelector ).addClass( "left drawer" ).css('display', 'none');

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
