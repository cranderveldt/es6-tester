const doubler = (v) => v * 2

jQuery(document).on("ready", => {
  jQuery("body").html(`10 times 2 is #{doubler(10)}`)
})