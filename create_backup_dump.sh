DATE=`date +%m_%d_%Y.dump`
pg_dump ucbpblmembersportal_development > "dumps/$DATE"
cd dumps
git add .
git commit -m "added $DATE"
git push origin master
cd ..
echo "pushed $DATE to dumps git repo!"
