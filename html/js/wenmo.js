$(document).on('click', '.wenmo-send-money-btn', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#wenmo-box-new-for-give').fadeIn(350);
});

$(document).on('click', '#wenmo-send-money-ended', function(e){
    e.preventDefault();
    var id = $(".wenmo-input-one").val();
    var amount = $(".wenmo-input-two").val();
    var reason = $(".wenmo-input-three").val();
    if ((id || amount || reason != '') && (id && amount) >= 1){
        $.post('https://qb-phone/wenmo_givemoney_toID', JSON.stringify({
            id: id,
            amount: amount,
            reason: reason,
        }));
        
        ClearInputNew()
        $('#wenmo-box-new-for-give').fadeOut(350);
    }
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "ChangeMoney_Wenmo":
                var date = new Date();
                var hour = date.getHours() + ":" + date.getMinutes();

                var AddOption = `<div style="color: ${event.data.color}" class="wenmo-form-style-body">${event.data.amount}<div class="wenmo-time-class-body">${hour}</div>`;
                if (event.data.reason != false) {
                    AddOption += `<div class="wenmo-reason-class-body">${event.data.reason}</div>`
                };
                AddOption += `</div>`

                console.log(AddOption)

                $('.wenmo-list').prepend(AddOption);
            break;
        }
    })
});