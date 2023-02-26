public interface ITriggerHandler {

    void BeforeInsert(List<SObject> newItems);

    void BeforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    void BeforeDelete(Map<Id, SObject> oldMap);

    void AfterInsert(Map<Id, SObject> newMap);

    void AfterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    void AfterDelete(Map<Id, SObject> oldMap);

    void AfterUndelete(Map<Id, SObject> oldMap);

    Boolean IsDisabled();
}