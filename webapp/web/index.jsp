<%--***********************************************************************

 Эксклюзивные права i Teco, ЗАО.                                       
 (c) Copyright i-Teco, CJSK. 2013                                      
 All Rights reserved.                                                  
 Данные исходные коды не могут использоваться и быть изменены          
 без официального разрешения компании i-Teco                           

***************************************************************************

 Project                                                               
 Module                                                                
 File           ${NAME}                                                
 Description                                                           
 Created by     g.alexeev (g.alexeev@i-teco.ru)                            
 Created on     17.08.13                                                

***********************************************************************--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta charset="utf-8"/>
    <script src="${pageContext.request.contextPath}/js/jquery-2.0.3.js"></script>
    <script src="${pageContext.request.contextPath}/js/tree.jquery.js"></script>
    <script src="${pageContext.request.contextPath}/js/jquery-ui.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style/jqtree.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style/ui-lightness/jquery-ui.css">
    <title>Orgstructure_tree</title>
    <style>
        body {
            font-size: 100%;
        }

        label, input {
            display: block;
        }

        input.text {
            margin-bottom: 12px;
            width: 95%;
            padding: .4em;
        }

        fieldset {
            padding: 0;
            border: 0;
            margin-top: 25px;
        }

        div#tree {
            border: 1px solid navy;
        }

        h1 {
            font-size: 1.2em;
            margin: .6em 0;
        }

        .ui-dialog .ui-state-error {
            padding: .3em;
        }

        .validateTips {
            border: 1px solid transparent;
            padding: 0.3em;
        }
    </style>
    <script>
        $(function () {
            var first_name = $("#first_name"),
                    last_name = $("#last_name"),
                    middle_name = $("#middle_name"),
                    type = $("#selector"),
                    allFields = $([]).add(first_name).add(last_name).add(middle_name),
                    tips = $(".validateTips");

            function updateTips(t) {
                tips
                        .text(t)
                        .addClass("ui-state-highlight");
                setTimeout(function () {
                    tips.removeClass("ui-state-highlight", 1500);
                }, 500);
            }

            function checkLength(o, n, min, max) {
                if (o.val().length > max || o.val().length < min) {
                    o.addClass("ui-state-error");
                    updateTips("Length of " + n + " must be between " +
                            min + " and " + max + ".");
                    return false;
                } else {
                    return true;
                }
            }

            function checkRegexp(o, regexp, n) {
                if (!( regexp.test(o.val()) )) {
                    o.addClass("ui-state-error");
                    updateTips(n);
                    return false;
                } else {
                    return true;
                }
            }

            $("#dialog-form").dialog({
                closeOnEscape: true,
                autoOpen: false,
                height: 400,
                width: 350,
                modal: true,
                buttons: {
                    "Create": function () {
                        var $this = $(this);
                        var bValid = true;
                        allFields.removeClass("ui-state-error");

                        var json_string;

                        if ("employee" == type.val()) {
                            bValid = bValid && checkLength(first_name, "first_name", 3, 16);
                            bValid = bValid && checkLength(last_name, "last_name", 3, 16);
                            bValid = bValid && checkLength(middle_name, "middle_name", 3, 16);
//                            bValid = bValid && checkLength($("#department"), "department", 3, 16);

                            json_string = JSON.stringify(
                                    {
                                        type: type.val(),
                                        first_name: first_name.val(),
                                        last_name: last_name.val(),
                                        middle_name: middle_name.val(),
                                        department_id: $("#dep_id").val()
                                    });
                        } else if ("department" == type.val()) {
//                           //TODO:department creation
                        }

                        if (bValid) {
                            $.post(
                                    '${pageContext.request.contextPath}/rest/tree/',
                                    {
                                        json_data: json_string
                                    },
                                    function (data) {
                                        if (data == 'success') {
                                            $this.dialog("close");
                                        }
                                    }
                            );
                        }
                    },
                    Cancel: function () {
                        $(this).dialog("close");
                    }
                },
                close: function () {
                    allFields.val("").removeClass("ui-state-error");
                    location.href = location.href;
                }
            });

            $("#create")
                    .button()
                    .click(function () {
                        $("#dialog-form").dialog("open");
                    });

            $('#selector').change(function () {
                var x = $(this).val();
                $('#type_selector').hide();

                if ("department" == x) {
                    $('#create_department').show();
                } else if ("employee" == x) {
                    $('#create_user').show();
                }
            });

            //TODO: can we create dynamic autocomplete function for different fields.
            $("#department").autocomplete({
                source: function (request, response) {
                    $.getJSON(
                            '${pageContext.request.contextPath}/rest/data/?term=' + request.term,
                            function (data) {
                                response($.map(data, function (item) {
                                    return {
                                        label: item.label,
                                        value: item.label,
                                        dep_id: item.id
                                    }
                                }));
                            }
                    );
                },
                minLength: 2,
                select: function (event, ui) {
//                    $(this).val(ui.item.label);
                    $('#dep_id').val(ui.item.dep_id);

//                    log(ui.item ?
//                            "Selected: " + ui.item.label :
//                            "Nothing selected, input was " + this.value);
                },
                focus: function (event, ui) {
//                    this.(ui.item.name);
                    $('#dep_id').val(ui.item.value);
                }
            });
        });
    </script>
</head>
<body>
<button id="create">Создать</button>
<div id="dialog-form" title="Create node">
    <p class="validateTips">All form fields are required.</p>

    <form id="type_selector">
        <label for="selector">Select object to create</label>
        <select id="selector" name="selector">
            <option value="">Choose value</option>
            <option value="department">Department</option>
            <option value="employee">Employee</option>
        </select>
    </form>

    <form id="create_user" hidden>
        <fieldset>
            <label for="first_name">First name</label>
            <input type="text" name="first_name" id="first_name" class="text ui-widget-content ui-corner-all"/>
            <label for="middle_name">Middle name</label>
            <input type="text" name="middle_name" id="middle_name" class="text ui-widget-content ui-corner-all"/>
            <label for="last_name">Last name</label>
            <input type="text" name="last_name" id="last_name" class="text ui-widget-content ui-corner-all"/>
            <label for="department">Department</label>
            <input type="text" name="department" id="department"
                   class="text ui-widget-content ui-corner-all"/>
            <input type="hidden" id="dep_id"/>
        </fieldset>
    </form>

    <form id="create_department" hidden>
        <fieldset>
            <label for="dep_name">Department name</label>
            <input type="text" name="dep_name" id="dep_name"
                   class="text ui-widget-content ui-corner-all"/>
            <label for="parent_dep_name">Parent department name</label>
            <input type="text" name="parent_dep_name" id="parent_dep_name"
                   class="text ui-widget-content ui-corner-all"/>
            <input type="hidden" id="parent_dep_id"/>
        </fieldset>
    </form>
</div>

<div id="tree" style="width:100%; margin:0; padding: 10px" data-url='${pageContext.request.contextPath}/rest/tree/'>
    <script type="text/javascript">
        $.getJSON(
                '${pageContext.request.contextPath}/rest/tree/',
                function (data) {
                    $('#tree').tree({
                        data: data,
                        autoOpen: false
                    });
                }
        );
    </script>
</div>
</body>
</html>