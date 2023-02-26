public class TravelFundExpenseReminderSchedular implements Schedulable {
    public static void execute(SchedulableContext bc) {
        Database.executeBatch(new TravelFundExpenseReminderBatch());
    }
}