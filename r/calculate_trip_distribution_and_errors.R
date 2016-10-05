############ Trip distribution matrix


#combine trip matricies
total_matrix <- merge(results$trip.matrx[[1]], results$trip.matrx[[2]], all = TRUE, by=c("origin", "dest"))
total_matrix <- merge(total_matrix, results$trip.matrx[[3]], all = TRUE, by=c("origin", "dest"))
total_matrix[is.na(total_matrix)] <- 0 #convert all NA to 0
total_matrix$dest <- as.numeric(substr(total_matrix$dest, 2, 5)) #remove x from start of destination
total_matrix <- total_matrix %>% mutate(total = purpose.1 + purpose.2 + purpose.3)




########### Calculate errors
tsrc.by.purpose <- s_trips %>% 
  group_by (lvl2_orig, lvl2_dest) %>%
  summarise(total = sum(daily.weight)) %>% #need to scale weight by number of years, and to a daily count
  rename (origin = lvl2_orig, dest = lvl2_dest)
errors <- merge(total_matrix, tsrc.by.purpose, by=c("origin", "dest"), all=FALSE)
errors <- errors %>% mutate(abs_err = abs(total.x - total.y),
                            rel_err = abs_err / total.y)


