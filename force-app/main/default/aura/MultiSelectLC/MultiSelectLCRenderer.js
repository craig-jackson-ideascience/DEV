({

    afterRender: function (component, helper) {
        this.superAfterRender();
        console.log('INSIDE AFTER RENDERER');
    },

    rerender: function (component, helper) {
        this.superRerender();
        console.log('INSIDE Re-Renderer');
        //document.removeEventListener('click', helper.windowClick);
        /* helper.windowClick = function (e) {
            if (e.target.toString().includes('HTMLDivElement')) { //If its normal div element, close drodown
                helper.closeDropdown(component);
                document.removeEventListener('click', helper.windowClick); //Remove event listner so that it doesn't interfere in other clicks in remaining document
            } else {
                //do nothing, helper methods will handle click of icon
            }
        }
        document.addEventListener('click', helper.windowClick); */
        /* helper.windowClick= function(e) {
            if(e.target.toString().includes('HTMLDivElement')) {           //If its normal div element, close drodown
                helper.closeDropdown(component);
               document.removeEventListener('click',helper.windowClick);   //Remove event listner so that it doesn't interfere in other clicks in remaining document
            } 
            else{
                 //do nothing, helper methods will handle click of icon
            }
        }
        document.addEventListener('click',helper.windowClick); */
    },

    unrender: function (component, helper) {
        this.superUnrender();

         /* document.removeEventListener('click', helper.windowClick);  */
    }
})