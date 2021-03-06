/*
k* Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
 * Author: Jim Palmer (based on chunking idea from Dave Koelle)
 * Contributors: Mike Grier (mgrier.com), Clint Priest, Kyle Adams, guillermo
 * See: http://js-naturalsort.googlecode.com/svn/trunk/naturalSort.js
 */

function naturalSort (a, b) {
    var re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/gi,
        sre = /(^[ ]*|[ ]*$)/g,
        dre = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,
        hre = /^0x[0-9a-f]+$/i,
        ore = /^0/,
        // convert all to strings and trim()
        x = a.toString().replace(sre, '') || '',
        y = b.toString().replace(sre, '') || '',
        // chunk/tokenize
        xN = x.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        yN = y.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        // numeric, hex or date detection
        xD = parseInt(x.match(hre)) || (xN.length != 1 && x.match(dre) && Date.parse(x)),
        yD = parseInt(y.match(hre)) || xD && y.match(dre) && Date.parse(y) || null;
    // first try and sort Hex codes or Dates
    if (yD)
        if ( xD < yD ) return -1;
        else if ( xD > yD )  return 1;
    // natural sorting through split numeric strings and default strings
    for(var cLoc=0, numS=Math.max(xN.length, yN.length); cLoc < numS; cLoc++) {
        // find floats not starting with '0', string or 0 if not defined (Clint Priest)
        var oFxNcL = !(xN[cLoc] || '').match(ore) && parseFloat(xN[cLoc]) || xN[cLoc] || 0;
        var oFyNcL = !(yN[cLoc] || '').match(ore) && parseFloat(yN[cLoc]) || yN[cLoc] || 0;
        // handle numeric vs string comparison - number < string - (Kyle Adams)
        if (isNaN(oFxNcL) !== isNaN(oFyNcL)) return (isNaN(oFxNcL)) ? 1 : -1;
        // rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
        else if (typeof oFxNcL !== typeof oFyNcL) {
            oFxNcL += '';
            oFyNcL += '';
        }
        if (oFxNcL < oFyNcL) return -1;
        if (oFxNcL > oFyNcL) return 1;
    }
    return 0;
}

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "natural-asc": function ( a, b ) {
        return naturalSort(a,b);
    },

    "natural-desc": function ( a, b ) {
        return naturalSort(a,b) * -1;
    },

    "without-punc-pre": function ( a ) {
        return a.replace(/("|'|\[|<[^>]*>)/g, '');
    },
    "without-punc-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },
    "without-punc-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );

(function($) {
/*
 * Function: fnGetColumnData
 * Purpose:  Return an array of table values from a particular column.
 * Returns:  array string: 1d data array
 * Inputs:   object:oSettings - dataTable settings object. This is always the last argument past to the function
 *           int:iColumn - the id of the column to extract the data from
 *           bool:bUnique - optional - if set to false duplicated values are not filtered out
 *           bool:bFiltered - optional - if set to false all the table data is used (not only the filtered)
 *           bool:bIgnoreEmpty - optional - if set to false empty values are not filtered from the result array
 * Author:   Benedikt Forchhammer <b.forchhammer /AT\ mind2.de>
 */
$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
    // check that we have a column id
    if ( typeof iColumn == "undefined" ) return new Array();

    // by default we only want unique data
    if ( typeof bUnique == "undefined" ) bUnique = true;

    // by default we do want to only look at filtered data
    if ( typeof bFiltered == "undefined" ) bFiltered = true;

    // by default we do not want to include empty values
    if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;

    // list of rows which we're going to loop through
    var aiRows;

    // use only filtered rows
    if (bFiltered == true) aiRows = oSettings.aiDisplay;
    // use all rows
    else aiRows = oSettings.aiDisplayMaster; // all row numbers

    // set up data array
    var asResultData = new Array();

    for (var i=0,c=aiRows.length; i<c; i++) {
        iRow = aiRows[i];
        var aData = this.fnGetData(iRow);
        var sValue = aData[iColumn];

        // ignore empty values?
        if (bIgnoreEmpty == true && sValue.length == 0) continue;

        // ignore unique values?
        else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;

        // else push the value onto the result data array
        else asResultData.push(sValue);
    }

    return asResultData;
}}(jQuery));


function fnCreateSelect( aData )
{
    aData = aData.sort();
    var r='<select><option value=""></option>', i, iLen=aData.length;
    for ( i=0 ; i<iLen ; i++ )
    {
        r += '<option value="'+aData[i]+'">'+aData[i]+'</option>';
    }
    return r+'</select>';
}

$(document).ready(function() {
    $('.m').on('click', function(e) {
        e.preventDefault();
        $.get(rootUrl + 'works/' + $(this).data('i') + '/metadata', function(data) {
            $.modal(data, {
              close: true
            });
        });
    });
    var table = $('table.works').dataTable({
        oLanguage: {
          sSearch: "Search within these results: "
        },

        bStateSave: true,

        aoColumnDefs: [
        {
          sType: "natural",
          aTargets: [ 'work-number' ]
        }, {
            sType: "without-punc",
            aTargets: [ 'work-title' ]
        }
        ],

        fnInitComplete: function() {
          $('#work-table-wrapper').show();
        }
    });

    $("th.edition-footer, th.date-footer, th.recipient-footer").each( function () {
        var i = $(this).index();
        this.innerHTML = fnCreateSelect( table.fnGetColumnData(i) );
        $('select', this).change( function () {
            table.fnFilter( $(this).val(), i );
        } );
    } );

    $('.flash.wait').insertAfter('header');
    $('#new_edition #edition_submit_action input').on('click', function() {
        $('.flash').hide();
        setTimeout(function() { $('.flash.wait').show(); }, 400);
    });

    $('.show-metadata').on('click', function(e) {
        e.preventDefault();
        $(this).parent().find('.metadata').modal({
          close: true
        });
    });


    $('.toggler, .right-toggler').on('click', function() {
        $(this).toggleClass('expanded').next('.toggleable').slideToggle(200);
    });

    if ( $( 'body.works.edit' ).length ) {
      $( '.metadata-inputs' ).on( 'click', '.remove-field', function( ) {
        $( this ).closest( 'label' ).remove();
        return false;
      } );

      $( '#btn-add-field' ).click( function() {
        var fieldName = $( '#add-field' ).val();
        if ( fieldName.length ) {
          $( '.metadata-inputs' ).append( '<label><span>' + fieldName + '</span><input type="text" name="work[metadata][' + fieldName + ']" value="" /></label>' );
          $( '#add-field' ).val('');
        }
      } );
    }
});
