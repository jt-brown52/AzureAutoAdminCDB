# Login to Azure
Connect-AzAccount

# Select the Azure subscription
$subscriptionId = "your-subscription-id"
Select-AzSubscription -SubscriptionId $subscriptionId

# Define the budget parameters
$budgetName = "MonthlyBudget"
$budgetAmount = 600
$timeGrain = "Monthly"
$startDate = (Get-Date).ToString("yyyy-MM-01T00:00:00Z")
$category = "Cost"
$notificationKey1 = "Actual_GreaterThan_80_Percent"
$notificationKey2 = "Actual_GreaterThan_100_Percent"

# Create notifications
$notifications = @{
    $notificationKey1 = @{
        "enabled" = $true
        "operator" = "GreaterThan"
        "threshold" = 80
        "contactEmails" = @("your-email@example.com")
        "contactRoles" = @("Contributor", "Reader")
        "thresholdType" = "Actual"
    }
    $notificationKey2 = @{
        "enabled" = $true
        "operator" = "GreaterThan"
        "threshold" = 100
        "contactEmails" = @("your-email@example.com")
        "contactRoles" = @("Contributor", "Reader")
        "thresholdType" = "Actual"
    }
}

# Create the budget
New-AzConsumptionBudget -BudgetName $budgetName -Amount $budgetAmount -Category $category -TimeGrain $timeGrain -StartDate $startDate -NotificationKey $notificationKey1 -NotificationEnabled $true -NotificationThreshold 80 -NotificationContactEmails "your-email@example.com"
New-AzConsumptionBudget -BudgetName $budgetName -Amount $budgetAmount -Category $category -TimeGrain $timeGrain -StartDate $startDate -NotificationKey $notificationKey2 -NotificationEnabled $true -NotificationThreshold 100 -NotificationContactEmails "your-email@example.com"

Write-Output "Budget of $${budgetAmount} has been set for subscription ID: $subscriptionId"
