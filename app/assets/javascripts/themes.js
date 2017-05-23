$(document).ready(function () {
    $("#theme_table").on("click", "tr .btn-delete", function () {
        $("#delete_confirm_dialog").modal('show');
        var theme_id_to_delete = $('.theme_id', $(this).closest('tr')).html();
        $("#delete_confirm_dialog").data("theme_id_to_delete", theme_id_to_delete);
    });

    $("#delete_confirm_dialog .btn-primary").click(function () {
        var a = $("#delete_confirm_dialog").data("theme_id_to_delete");

        $.post('themes/' + a + '/delete', function () {
            location.reload();
        });
    });

    $("#theme_table").on("click", "tr .btn-edit", function () {
        var row = $(this).closest('tr');
        var theme_id_to_edit = $('.theme_id', row).html();
        var theme_name = $('.theme-name', row).data('theme-name');
        var theme_type = $('.theme-type', row).data('theme-type');
        var theme_status = $('.theme-status', row).data('theme-status');

        $('#edit_theme_dialog #theme_id').val(theme_id_to_edit);
        $('#edit_theme_dialog #add-name').val(theme_name);
        $('#edit_theme_dialog #add-type').val(theme_type);
        if(theme_status)
        {
            $('#edit_theme_dialog #add-status').attr('checked', 'true');
        }
        else{
            $('#edit_theme_dialog #add-status').removeAttr('checked');
        }


        $("#delete_confirm_dialog").data("theme_id_to_delete",
            {
                'theme_id': theme_id_to_edit,
                'theme_name': theme_name,
                'theme_type': theme_type,
                'theme_status': theme_status
            });
        $("#edit_theme_dialog").modal('show');
    });

    $("#theme_assigned_users").on("click", "tr .btn-delete", function () {
        $("#unassign_confirm_dialog").modal('show');
        var theme_id = $('#theme_assigned_users table').data('theme-id');
        var user_id = $(this).closest('tr').data('user-id');
        $("#unassign_confirm_dialog").data("theme-id", theme_id);
        $("#unassign_confirm_dialog").data("user-id", user_id);

    });

    $("#unassign_confirm_dialog .btn-primary").click(function () {
        var theme_id = $("#unassign_confirm_dialog").data("theme-id");
        var user_id = $("#unassign_confirm_dialog").data("user-id");
        $.post('/dashboard/themes/' + theme_id + '/unassign', {'user_ids': [user_id]}, function () {
            location.reload();
        });
    });
    $("#theme_assigned_users").on("click", "tr .btn-edit", function () {
        var row = $(this).closest('tr');
        var user_id = row.data('user-id');
        var activated_date = $('.activated-date', row).html();
        var expire_date = $('.expire-date', row).html();
        $('#edit_assignment_dialog #account_id').val(user_id);
        $('#edit_assignment_dialog #activated_date_input').val(activated_date);
        $('#edit_assignment_dialog #expire_date_input').val(expire_date);
        $("#edit_assignment_dialog").modal('show');
    });
});
