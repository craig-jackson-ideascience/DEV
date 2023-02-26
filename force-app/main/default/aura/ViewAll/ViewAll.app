<aura:application extends="force:slds">
        <aura:attribute name="pageid" type="String" default="this is default value"/>
        <aura:attribute name="type" type="String" default="this is default value"/>
  <!--<c:TestComponent recordId="{!v.pageid}"></c:TestComponent>-->
    <aura:if isTrue="{!v.type =='training'}">
    <c:accountSponsorshipTrainingSummary newRecordId="{!v.pageid}"></c:accountSponsorshipTrainingSummary>
    </aura:if>
    <aura:if isTrue="{!v.type =='event'}">
    <c:accountSponsorshipSummary newRecordId="{!v.pageid}"></c:accountSponsorshipSummary>
    </aura:if>
    </aura:application>