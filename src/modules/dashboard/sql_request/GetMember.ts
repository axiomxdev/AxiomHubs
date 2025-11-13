import { dbManager } from "../../db/DB_manager";
import { User } from "../../../types/db";

export async function GetMember() {
    const member = await dbManager.query("SELECT * FROM users") as User[];

    /**
     * Mounthly Growth
     */
    const newMemberMounthly = member.filter((user: User) => {
        const createdAt = new Date(user.created_at);
        const monthAgo = new Date();
        monthAgo.setDate(monthAgo.getDate() - 30);
        return createdAt >= monthAgo;
    }).length;

    let oldMemberMounthly = member.length - newMemberMounthly;
    if (!(oldMemberMounthly > 0))
        oldMemberMounthly = 1;

    const usersGrowthMounthly = Math.round((newMemberMounthly / oldMemberMounthly) * 100 * 100) / 100;

    /**
     * Weekly Growth
     */
    const newMemberWeekly = member.filter((user: User) => {
        const createdAt = new Date(user.created_at);
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return createdAt >= weekAgo;
    }).length;

    let oldMemberWeekly = member.length - newMemberWeekly;
    if (!(oldMemberWeekly > 0))
        oldMemberWeekly = 1;

    const usersGrowthWeekly = Math.round((newMemberWeekly / oldMemberWeekly) * 100 * 100) / 100;

    const Stats = {
        monthly: {
            totalUsers: member.length,
            usersGrowth: usersGrowthMounthly
        },
        weekly: {
            usersGrowth: usersGrowthWeekly
        }
    };

    return Stats;
}
