$(function() {
    $('.reading-list-link').on('click', function() {
        $('.reading-list-heading').each(function() {
            var header = $(this);
            $.get(header.data('reading-list'), function(data) {
                header.next('.reading-list').replaceWith(data);
            });
        });
    });
});
