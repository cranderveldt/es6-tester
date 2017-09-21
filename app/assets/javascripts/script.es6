const doubler = (v) => v * 2


jQuery(document).on("ready", function() {
  console.log(`10 times 2 is ${doubler(10)}`)
  jQuery("body").html(`10 times 2 is ${doubler(10)}`)
})