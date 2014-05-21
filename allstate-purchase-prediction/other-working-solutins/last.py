from __future__ import division
 
import sqlite3
 
db = sqlite3.connect('db')
 
def p_ben(n, history_length):
    p_remove = 1/3 # .3
    p_keep = 1 - p_remove
 
    if n == 1:
        return 0.
    if n == history_length:
        return p_keep ** (n-2) 
 
    return p_keep ** (n-2) * p_remove
 
def main():
    zero_mistakes = 0.
    total = 0
 
    for cid, history_size in db.execute('SELECT customer_id, max(shopping_pt) FROM train WHERE record_type = 0 GROUP BY customer_id'):
        labels = db.execute('SELECT A,B,C,D,E,F,G FROM train WHERE customer_id = ? AND record_type = 1', (cid,)).fetchone()
 
        for i in range(2, history_size+1):
            last_quoted = db.execute('SELECT A,B,C,D,E,F,G FROM train WHERE shopping_pt = ? AND customer_id = ? AND record_type = 0', (i, cid)).fetchone()
 
            if labels == last_quoted:
                zero_mistakes += p_ben(i, history_size)
        
        total += 1
 
    print round(zero_mistakes / total, 4)
 
if __name__ == "__main__":
    main()
